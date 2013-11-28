package mchernan;

/*
 * Copyright (c) 1995, 2013, Oracle and/or its affiliates. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 *   - Neither the name of Oracle or the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */ 

import java.io.*;
import java.net.*;

public class EchoClientStdInput {
	static PrintWriter out = null;
	static BufferedReader in = null;

	static String hostName = "128.2.109.20";
	static int portNumber = 1025;
	static int reply = 0;

	static String [] commands = {
		"1,0,0",
		"0,1,0",
		"0,0,1",
		"-1,0,0",
		"0,-1,0",
		"0,0,-1"
	};

	public static void main(String[] args) throws IOException {
		try {
			Socket echoSocket = new Socket(hostName, portNumber);
			out = new PrintWriter(echoSocket.getOutputStream(), true);
			in = new BufferedReader(new InputStreamReader(echoSocket.getInputStream()));
			BufferedReader stdIn = new BufferedReader(new InputStreamReader(System.in));

			/*
			String userInput;
			while ((userInput = stdIn.readLine()) != null) {
			}
			 */
			for (int j = 0; j < 10; j++) {
				for (int i = 0; i < commands.length; i++) {
					ProcessCommand(commands[i]);
				}
			}
		} catch (UnknownHostException e) {
			System.err.println("Don't know about host " + hostName);
			System.exit(1);
		} catch (IOException e) {
			System.err.println("Couldn't get I/O for the connection to " + hostName);
			System.exit(1);
		} 
	}

	public static void ProcessCommand (String rawCommand) throws IOException {
		if (rawCommand.equals("0")) {
			System.err.println("Error");
			return;
		}

		String[] result = rawCommand.split(",");

		System.out.println("dx = " + result[0] + ", dy = " + result[1] + ", dz = " + result[2]);
		String commandString = "[" + result[0] + "," + result[1] + "," + result[2]+ "]";

		System.out.println("Sending: " + commandString);
		out.println(commandString);

		reply = in.read();
		switch (reply) {
		case -1:  System.err.println("No reply"); break;
		case 1:  System.out.println("OK"); break;
		case 2:  System.err.println("ERROR"); break;
		case 3:  System.out.println("CLOSING CONNECTION"); break;
		}
	}
}
