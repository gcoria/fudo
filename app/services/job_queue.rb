class JobQueue
  def initialize
    @queue = Queue.new
    @worker_thread = Thread.new do
      loop do
        begin
          job = @queue.pop
          job.call
        rescue => e
          puts "Error processing job: #{e.message}"
          puts e.backtrace.join("\n")
        end
      end
    end
  end

  def enqueue(&block)
    @queue.push(block)
  end

  def shutdown
    @worker_thread.kill if @worker_thread.alive?
  end
end 