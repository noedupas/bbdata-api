FROM registry.forge.hefr.ch/noe.dupasqui/ps5-sensbox:latest

# Copy configs
COPY config.json .
COPY sensor_config.json .

CMD ["python3", ".", "start", "--config-sensor", "sensor_config.json", "--config", "config.json"]