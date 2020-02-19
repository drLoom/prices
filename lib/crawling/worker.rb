require_relative 'crawler'

class Worker
  def initialize(pool, parser, job, processed_jobs)
    @pool  = pool
    @parser = parser
    @job    = job
    @processed_jobs = processed_jobs
  end

  def do_job
    response = Crawler.new.fetch(@job)

    @parser.new.send(@job[:callback], response, @job[:data]) do |next_job|
      @pool.post { Worker.new(@pool, @parser, next_job, @processed_jobs).do_job }
    end

  ensure
    @processed_jobs << { }
  end
end
