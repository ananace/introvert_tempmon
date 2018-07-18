require 'json'
require 'net/http'

module IntrovertTempmon
  class Machine
    attr_accessor :hostname, :port

    def initialize(hostname, port = 19_999)
      if hostname.is_a? URI
        hostname = hostname.host
        port = hostname.port
      end

      @hostname = hostname
      @port = port
    end

    def temperature_sensors
      @temperature_sensors ||= begin
        resp = http.get(URI("http://#{hostname}:#{port}/api/v1/charts"))
        resp.value
        charts = JSON.parse(resp.body, symbolize_names: true)

        charts[:charts]
          .select { |_k, chart| chart[:family] == 'temperature' }
          .map { |_k, chart| chart }
      end
    end

    def load_data(points = 1)
      resp = http.get(URI("http://#{hostname}:#{port}/api/v1/data?chart=system.load&points=#{points + 1}"))
      resp.value
      data = JSON.parse(resp.body, symbolize_names: true)

      Hash[data[:labels].map.with_index do |label, i|
        [label, data[:data].map { |point| point[i] }]
      end]
    end

    def temperature_data(points = 1)
      sensors = {}
      temperature_sensors.each do |sensor|
        resp = http.get(URI("http://#{hostname}:#{port}/api/v1/data?chart=#{sensor[:id]}&points=#{points + 1}"))
        resp.value
        data = JSON.parse(resp.body, symbolize_names: true)

        sensordata = sensors[sensor[:id]] = {}
        data[:labels].reject { |l| l == 'time' }.each.with_index do |label, i|
          sensordata[label] = []
          data[:data].each do |point|
            sensordata[label] << { time: point.first, data: point[i + 1] }
          end
        end
      end

      sensors
    end

    def avg_temperature(points = 1)
      temp = 0.0
      count = 0

      temperature_data(points).select { |s, _d| s =~ /coretemp/ }.each do |_s, data|
        data.each do |_name, counter|
          temp += counter.inject(0) { |n, p| count += 1; n + p[:data] }
        end
      end

      temp / count.to_f
    end

    private

    def http
      @http ||= Net::HTTP.new hostname, port
      return @http if @http.active?

      @http.start
    end
  end
end
