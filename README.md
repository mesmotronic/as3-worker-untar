Untar Worker for Adobe AIR
==========================

Untar Worker for Adobe AIR is an ActionScript 3 Worker class used to extract 
uncompressed gnu-tar files, created using `tar -cf`, in the background.

The Worker runs once, then self-terminates on completion.

Released under BSD license. Requires AIR 3.4+.

Example Project
---------------

A simple Flex project for Adobe AIR example Flash Builder project is included in the examples folder, which enables you to select and extract a tar to a chosen folder.

Code Example
------------

```as3
protected var untarWorker:Worker;
protected var resultChannel:MessageChannel;

[Embed(source="UntarWorker.swf", mimeType="application/octet-stream")]
protected var untarWorkerClass:Class;

protected function untar(sourcePath:String, targetPath:String):void
{
	// giveAppPrivileges parameter MUST be set to true!
	untarWorker = WorkerDomain.current.createWorker(new untarWorkerClass(), true);
	untarWorker.addEventListener(Event.WORKER_STATE, untarWorker_workerStateHandler);
	
	resultChannel = untarWorker.createMessageChannel(Worker.current);
	resultChannel.addEventListener(Event.CHANNEL_MESSAGE, resultChannel_channelMessage);
	
	untarWorker.setSharedProperty("sourcePath", sourcePath);
	untarWorker.setSharedProperty("targetPath", targetPath);				
	untarWorker.setSharedProperty("resultChannel", resultChannel);				
	
	untarWorker.start();
}

protected function untarWorker_workerStateHandler(event:Event):void
{
	trace("untarWorker.state =", untarWorker.state);
}

protected function resultChannel_channelMessage(event:Event):void
{
	var success:Boolean = resultChannel.receive() as Boolean;
	
	switch (success)
	{
		case true:
			true("Success!");
			break;
			
		default:
			trace("Error: are you sure that was a tar?");
			break;
	}
}
```
