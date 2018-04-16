/* Copyright (C) 2016 Xendke
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*/
using GLib;
using Authenticator;


namespace Authenticator.Services {

errordomain InvalidSecretError {
	INVALID_CHAR
}
errordomain InvalidURI {
	NOT_TOTP
}
public uint8[] base32_decode(string input0) {
	string input = input0;
	while( input.has_suffix("=")) { // trim the  == padding
		input = input[0:input.length-1];
	}

	input = input.ascii_up (); // capitalize

	// http://stackoverflow.com/users/904128/shane from http://stackoverflow.com/questions/641361/base32-decoding

	int byteCount = input.length * 5 / 8; //this must be TRUNCATED
	uint8[byteCount] returnArray = {};
	for (int i = 0; i < byteCount; i++) {
		returnArray += 0x00;
	}

	uint8 curByte = 0, bitsRemaining = 8;
	int mask = 0, arrayIndex = 0;

	for (int i = 0; i < input.length; i++) {
		char c = input[i];
		int cValue = 0;
		try {
			cValue = base32_value_of (c);
		} catch (InvalidSecretError e ){
			stdout.printf ("Error: %s\n", e.message );
		}

		if (bitsRemaining > 5)
		{
			mask = cValue << (bitsRemaining - 5);
			curByte = (uint8)(curByte | mask);
			bitsRemaining -= 5;
		}
		else
		{
			mask = cValue >> (5 - bitsRemaining);
			curByte = (uint8)(curByte | mask);
			returnArray[arrayIndex++] = curByte;
			curByte = (uint8)(cValue << (3 + bitsRemaining));
			bitsRemaining += 3;
		}
	}

	//if we didn't end with a full byte
	if (arrayIndex != byteCount)
	{
		returnArray[arrayIndex] = curByte;
	}
	// for (int i = 0; i < returnArray.length; i++) {
	// 	stdout.printf ("%x ", returnArray[i]);
	// } stdout.printf ("\n");
	return returnArray;
}
private static int base32_value_of(char c) throws InvalidSecretError {
	int value = (int)c;

	//65-90 == uppercase letters
	if (value < 91 && value > 64)
	{
		return value - 65;
	}
	//50-55 == numbers 2-7
	if (value < 56 && value > 49)
	{
		return value - 24;
	}

	throw new InvalidSecretError.INVALID_CHAR("Character is not a Base32 character.");
}

private int hex_value_of(string bit) {
	switch(bit) {
	case "a":
		return 10;
	case "b":
		return 11;
	case "c":
		return 12;
	case "d":
		return 13;
	case "e":
		return 14;
	case "f":
		return 15;
	default:
		return int.parse(bit);
	}
}
private int hex_to_dec(uint8[] bytes){
	string[] s = {"","","",""};
	int decimal = 0;
	int count = 0;
	int coefficient = 0;
	for (int i = 3; i >= 0; i--) {
		s[i] = "%x".printf (bytes[i]);
		for (int j = 1; j >= 0 ; j--) {
			coefficient = (int)Math.pow (16, count);
			if(s[i].length == 1) {
				decimal += coefficient*(hex_value_of(s[i].to_string ()));
				count++;
				count++; // add 2 because the next halfbyte is 0 and not in s[i].
				break;
			}
			else{
				decimal += coefficient*(hex_value_of(s[i][j].to_string ()));
				count++;
			}
		}
	}
	return decimal;
}
public class TOTPManager {
	Hmac hmac;
	uint8[] digest = {};
	size_t digest_len;

	string secret;
	uint8[] secret_bytes;
	public string title;
	public string subtitle;
	string issuer;
	GLib.ChecksumType algorithm;
	int timestep;
	int digits;
	TOTPTimer timer;
	

	public signal void change_totp ();

	public TOTPManager (string URI) {
		disassemble_URI (URI);
		// timer.register (timestep);
		secret_bytes = base32_decode (secret);
		hmac = new Hmac (algorithm, secret_bytes);
		digest_len = 20; // 20-sha1, 32-sha256, 64? sha512
		for (int i = 0; i < digest_len; i++) {
			digest+= 0x00;
		}
		timer = new TOTPTimer (this.timestep);
		connect_signals ();
	}

	~TOTPManager () {
		this.timer.alive = false;
	}
	private void disassemble_URI (string URI) {
		title = "";
		subtitle = "";
		digits = 6;
		string[] parameters = {};
		algorithm = GLib.ChecksumType.SHA1;
		timestep = 30;
		if (URI.contains ("totp/")) {
			int start = 15;
			int col_index = URI.index_of (":", start);
			int quest_index = URI.index_of ("?");
			if (col_index == -1) {
				title = URI[start:quest_index];
			} else {
				title = URI[start:col_index];
				subtitle = URI[col_index+1:quest_index];
			}
			string rest = URI[quest_index+1:URI.length];
			parameters = rest.split ("&");
			foreach (string s in parameters) {
				if (s.length == 0) continue;
				int eq_index =s.index_of ("=");
				string param = s[0:eq_index];
				switch (param) {
				case "secret":
					secret = s[eq_index+1:s.length];
					break;
				case "algorithm":
					string salgorithm = s[eq_index+1:s.length];
					if(salgorithm == "SHA256"){
						algorithm = GLib.ChecksumType.SHA256;
					} else if(salgorithm == "SHA512"){
						algorithm = GLib.ChecksumType.SHA512;
					} else {
						algorithm = GLib.ChecksumType.SHA1;
					}
					break;
				case "period":
					timestep = int.parse (s[eq_index+1:s.length]);
					break;
				case "issuer":
					issuer = s[eq_index+1:s.length];
					break;
				case "digits":
					int tdigits = int.parse (s[eq_index+1:s.length]);
					stdout.printf ("digits: %d", tdigits);
					if(  tdigits == 6 ||  tdigits == 8) {
						digits = tdigits;
					} else {
						digits = 6;
					}
					break;
				default:
					stdout.printf ("URI Parameter not caught: %s\n", param);
					break;
				}
			}
		} else {
			throw new InvalidURI.NOT_TOTP ("URI is not type totp.");
		}
	}
	private uint8[] get_time (int timestep = 30) { // default timestep 30
		int64 real_time = get_real_time (); // microseconds
		uint64 ureal_time = (((uint64)real_time)/1000000) / timestep; //to seconds and per time step

		uint8[4] byteArray = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

		byteArray[0] = (uint8)((ureal_time >> 56) & 0xFF);
		byteArray[1] = (uint8)((ureal_time >> 48) & 0xFF);
		byteArray[2] = (uint8)((ureal_time >> 40) & 0xFF);
		byteArray[3] = (uint8)((ureal_time >> 32) & 0xFF);
		byteArray[4] = (uint8)((ureal_time >> 24) & 0xFF);
		byteArray[5] = (uint8)((ureal_time >> 16) & 0xFF);
		byteArray[6] = (uint8)((ureal_time >> 8) & 0xFF);
		byteArray[7] = (uint8)((ureal_time >> 0) & 0xFF);

		return byteArray;
	}
	public string get_current_totp () {
		uint8[] T = get_time (timestep);
		hmac = new GLib.Hmac (algorithm, secret_bytes);
		hmac.update (T);

		hmac.get_digest (digest, ref digest_len);

		uint8 offsetbyte = digest[digest_len-1];
		offsetbyte  &= ~(1 << 7);
		offsetbyte  &= ~(1 << 6);
		offsetbyte  &= ~(1 << 5);
		offsetbyte  &= ~(1 << 4);
		int offset = offsetbyte; // only use right-most 4 bits for offset.

		uint8[4] nbuffer = digest[offset:offset+4];

		//clear top bit to reach nbuffer of 31 bit.
		nbuffer[0]  &= ~(1 << 7);
		string full_totp = hex_to_dec (nbuffer).to_string ();
		return full_totp[full_totp.length-digits:full_totp.length];
	}
	private void check_for_update () {
		change_totp ();
	}
	private void connect_signals () {
		timer.time_is_up.connect (check_for_update);
	}
}
}
