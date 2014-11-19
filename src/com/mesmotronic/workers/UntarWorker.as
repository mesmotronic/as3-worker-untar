/*
Copyright (c) 2014, Neil Rackett
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

package com.mesmotronic.workers
{
	import flash.display.Sprite;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	
	import com.mesmotronic.utils.SimpleUntar;
	
	public class UntarWorker extends Sprite
	{
		public function UntarWorker()
		{
			var resultChannel:MessageChannel;
			var untar:SimpleUntar;
			
			resultChannel = Worker.current.getSharedProperty("resultChannel") as MessageChannel;
			
			untar = new SimpleUntar();
			untar.sourcePath = Worker.current.getSharedProperty("sourcePath");
			untar.targetPath = Worker.current.getSharedProperty("targetPath");
			
			trace(this, "Extracting", untar.sourcePath, "to", untar.targetPath, "...");
			
			try
			{
				untar.extract();
			}
			catch (e:Error)
			{
				trace(this, ":-(");
				
				untar.close();
				resultChannel.send(false);
				Worker.current.terminate();
			}
			
			trace(this, ":-)");
			
			untar.close();
			resultChannel.send(true);
			Worker.current.terminate();
		}
	}			
}
