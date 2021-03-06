package com.k_int.kbplus

import java.util.concurrent.ConcurrentHashMap

class ExecutorWrapperService {

	def executorService
	def genericOIDService
	ConcurrentHashMap<Object,java.util.concurrent.FutureTask> activeFuture = [:]

	def processClosure(clos,owner){
		log.debug('processClosure: ' + owner)
		def newOwner = "${owner?.class?.name}:${owner?.id}"
		//see if we got a process running for owner already
		def existingFuture = activeFuture.get(newOwner)
		if(!existingFuture){
			//start new thread and store the process
		      def future = executorService.submit(clos as java.util.concurrent.Callable)
		      activeFuture.put(newOwner,future)
		}else{
			//if a previous process for this owner is done, remove it and start new one
			if(existingFuture.isDone()){
				activeFuture.remove(newOwner)
				processClosure(clos,genericOIDService.resolveOID(newOwner))
			}
			//if not done, do something else
		}
	}

	def hasRunningProcess(owner){
		owner = "${owner.class.name}:${owner.id}"
		// There is no process running for this owner
		if(activeFuture.get(owner) == null){
			return false
		// there was a process, but now its done.
		}else if(activeFuture.get(owner).isDone()){
			activeFuture.remove(owner)
			return false
		// we have a running process
		}else if(activeFuture.get(owner).isDone() == false){
			return true
		}
	}
}

