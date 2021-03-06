/*
Copyright (c) 2014, Neil Rackett
All rights reserved.

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

package com.mesmotronic.utils 
{
	import com.mesmotronic.utils.untar.UntarFileInfo;
	import com.mesmotronic.utils.untar.UntarHeaderBlock;

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class SimpleUntar
	{
		public static const BLOCK_SIZE:uint = 512;
		public static const BLOCK_SIZE_FACTOR:Number = 1 / 512;
		public static const SAVEDBYTES_AT_ONCE:uint = 4*1024*1024; // 4 MB
		public static const CODE_PAGE:String = "iso-8859-1";
		
		private var _sourcePath:String;
		private var _targetPath:String;
		private var sourceFile:File;
		private var targetFile:File;
		private var sourceFileStream:FileStream;
		
		private var allFiles:Vector.<UntarFileInfo> = new Vector.<UntarFileInfo>();
		private var allDirectories:Vector.<UntarFileInfo> = new Vector.<UntarFileInfo>();
		private var tempFileInfo:UntarFileInfo;
		private var tempFile:File;
		private var tempFileStream:FileStream;
		private var tempBA:ByteArray = new ByteArray();

		// Switched to Number to support files larger than 2^32 bytes
		private var availBytes:Number;
		private var walkerPosition:Number;
		
		public function SimpleUntar()
		{
			super();
		}

		public function get sourcePath():String 
		{
			return _sourcePath;
		}

		public function set sourcePath(sourcePath:String):void 
		{
			_sourcePath = sourcePath;
			
			sourceFile = new File(sourcePath);
			
			if(sourceFile.exists)
			{
				sourceFileStream = new FileStream();
				sourceFileStream.open(sourceFile, FileMode.READ);
			
				getAllFilenames();
			}
		}
		
		public function get targetPath():String 
		{
			return _targetPath;
		}

		public function set targetPath(targetPath:String):void 
		{
			targetFile = new File(targetPath);
			
			if (!targetFile.exists)
			{
				targetFile.createDirectory();
			}
			
			_targetPath = targetPath;
		}
		
		public function extract():void
		{
			createDirs();
			createFiles();
		}
		
		public function close():void
		{
			sourceFileStream.close();
		}
		
		private function createDirs():void
		{
			for (var i:int = 0; i < allDirectories.length; i++) 
			{
				tempFile = targetFile.resolvePath(allDirectories[i].filename);
				
				if (!tempFile.exists)
				{
					tempFile.createDirectory();
				}
			}
		}
		
		private function createFiles():void
		{
			for (var i:int = 0; i<allFiles.length; i++) 
			{
				tempFileInfo = allFiles[i];
				tempFile = targetFile.resolvePath(allFiles[i].filename);
				
				if (tempFile.exists)
				{
					tempFile.deleteFile();
				}
				
				tempFileStream = new FileStream();
				tempFileStream.open(tempFile, FileMode.APPEND);
				
				availBytes = tempFileInfo.size;
				walkerPosition = tempFileInfo.startPosition;
				
				while (availBytes > SAVEDBYTES_AT_ONCE)
				{
					tempBA.clear();
					
					sourceFileStream.position = walkerPosition;
					sourceFileStream.readBytes(tempBA, 0, SAVEDBYTES_AT_ONCE);
					tempFileStream.writeBytes(tempBA);
					
					availBytes -= SAVEDBYTES_AT_ONCE;
					walkerPosition += SAVEDBYTES_AT_ONCE;
				}
				
				tempBA.clear();
				sourceFileStream.position = walkerPosition;
				sourceFileStream.readBytes(tempBA, 0, availBytes);
				tempFileStream.writeBytes(tempBA);
				
				tempFileStream.close();
			}
		}
		
		private function getAllFilenames():void
		{
			allFiles = new Vector.<UntarFileInfo>();
			allDirectories = new Vector.<UntarFileInfo>();
			
			var currentPosition:Number = 0;
			var hasNewBlock:Boolean = true;
			var savedLongFileName:String = '';
			
			while (hasNewBlock)
			{
				var bytes:ByteArray = new ByteArray();
				sourceFileStream.position = currentPosition;
				sourceFileStream.readBytes(bytes, 0, BLOCK_SIZE);
				
				var header:UntarHeaderBlock = new UntarHeaderBlock();
				header.byteArray = bytes;
				tempFileInfo = new UntarFileInfo();
				
				switch (header.type)
				{
					case UntarHeaderBlock.TYPE_NULL:
						hasNewBlock = false;
						break;
					
					case UntarHeaderBlock.TYPE_LONGFILENAME:
						sourceFileStream.position = currentPosition+BLOCK_SIZE;
						savedLongFileName = sourceFileStream.readMultiByte(header.size, CODE_PAGE);
						break;
					
					case UntarHeaderBlock.TYPE_FILE:
						
						tempFileInfo.startPosition = currentPosition+BLOCK_SIZE;
						tempFileInfo.size = header.size;
						if (savedLongFileName != '')
						{
							tempFileInfo.filename = savedLongFileName;
						} else {
							tempFileInfo.filename = header.filename;
						}
						allFiles.push(tempFileInfo);
						savedLongFileName = '';
						break;
					
					case UntarHeaderBlock.TYPE_DIR:
						if (savedLongFileName != '')
						{
							tempFileInfo.filename = savedLongFileName;
						} else {
							tempFileInfo.filename = header.filename;
						}
						allDirectories.push(tempFileInfo);
						savedLongFileName = '';
						break;
				}
				
				currentPosition = currentPosition+(header.size_blocks*BLOCK_SIZE)+BLOCK_SIZE;
				
				if ((sourceFileStream.bytesAvailable-tempFileInfo.size) < 512)
				{
					hasNewBlock = false;
				}
			}
		}
	}
}
