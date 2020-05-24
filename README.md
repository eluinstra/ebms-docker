Build and run example:
cd ebms-adapter-bin
docker build -t ebms-adapter-bin .
cd ../example/digipoort
docker build -t ebms-adapter-digipoort .
cd ../overheid
docker build -t ebms-adapter-overheid .
cd ..
docker-compose up