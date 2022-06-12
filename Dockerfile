FROM clojure:openjdk-11-tools-deps-1.11.1.1113-buster as build
ARG deprivare
WORKDIR /usr/src
RUN echo "Checking out Deprivare ${deprivare}"
RUN git clone --depth 1 --branch "${deprivare}" https://github.com/eatyourpeas/deprivare
WORKDIR /usr/src/deprivare
RUN clojure -T:build uber :out '"deprivare.jar"'

FROM amazoncorretto:11-alpine-jdk
ENV port 8002
COPY --from=build /usr/src/deprivare/deprivare.jar /deprivare.jar
COPY --from=index /depriv.db /depriv.db
EXPOSE ${port}
CMD java -XX:+UseContainerSupport -XX:MaxRAMPercentage=85 -XX:+UnlockExperimentalVMOptions -XX:+UseZGC -jar /deprivare.jar -a 0.0.0.0 --db snomed.db -p ${port} --allowed-origins "*" serve