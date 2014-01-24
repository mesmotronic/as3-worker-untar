/*
Copyright (c) 2012, Christoph Ketzler
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met: 

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer. 
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
*/

package de.ketzler.utils.untar {
	import de.ketzler.utils.SimpleUntar;

	import flash.utils.ByteArray;
	public class UntarHeaderBlock extends Object {
		
		public var debug:Boolean = true;
		
		
		public static const TYPE_NULL:uint = 0x0;
		public static const TYPE_FILE:uint = 0x30;
		public static const TYPE_DIR:uint = 0x35;
		public static const TYPE_LONGFILENAME:uint = 0x4c; // L,76
		
		public var size:uint;
		public var size_blocks:uint;
		public var type:uint;
		public var filename:String;
		
		
		private static const TAR_TYPE_POSITION:uint = 156;
		private static const TAR_NAME_POSITION:uint = 0;
		private static const TAR_NAME_SIZE:uint = 100;
		private static const TAR_SIZE_POSITION:uint = 124;
		private static const TAR_SIZE_SIZE:uint = 12;
		
		private var _ba : ByteArray = new ByteArray();
		private var tempString : String;
		
		public function UntarHeaderBlock() {
		}

		public function get byteArray() : ByteArray {
			return _ba;
		}

		public function set byteArray(ba : ByteArray) : void {
			
			
			_ba = ba;
			
			parseByteArray();
			
		}

		private function parseByteArray() : void {
			//trace('parse Header');
			
			// type
			_ba.position = UntarHeaderBlock.TAR_TYPE_POSITION;
			type = _ba.readByte();
			//trace('type: '+type+' = '+String.fromCharCode(type));
			
			// size
			_ba.position = TAR_SIZE_POSITION;
			tempString = _ba.readMultiByte(TAR_SIZE_SIZE, SimpleUntar.CODE_PAGE);
			//trace(tempString);
			
			
			size = parseInt(tempString, 8);
			if (size != 0)
			{
				if (size%SimpleUntar.BLOCK_SIZE == 0)
				{
					size_blocks = int(size*SimpleUntar.BLOCK_SIZE_FACTOR);
				} else {
					size_blocks = int(size*SimpleUntar.BLOCK_SIZE_FACTOR)+1;
				}
			} else {
				size_blocks = 0;
			}
			
			//trace('size: '+ size);
			
			// filename
			_ba.position = TAR_NAME_POSITION;
			filename = _ba.readMultiByte(TAR_NAME_SIZE, SimpleUntar.CODE_PAGE);
			
			//trace(tempString);
			//trace(tempString.length);
			
			
			return;
		}
		
		public function toString():String
		{
			return 'UntarHeader: Type: '+type + ' ('+String.fromCharCode(type)+'), size: '+size+' ('+size_blocks+' Blocks), filename: '+filename;
		}
		
	}
}
