FROM python:3.10-slim-buster

# Inside Container
# Make a new folder inside the Container
WORKDIR /backend-flask

# Outside Container --> Inside Container
# This containes the libraries we want to install to run the application 
COPY requirements.txt requirements.txt

# Inside Container
# Installs the Python libraries used for the application
RUN pip3 install -r requirements.txt

# Outside Container --> Inside Container
# . means everything in the directory
# first period . /backend-flask (outside of the container)
# second period . /backend-flask (inside the container)
COPY . .

# Sets Environment Variable
# Inside Container and will remain set until the container is running
ENV FLASK_ENV=development


EXPOSE ${PORT}

# CMD stands for command
# python3 -m flask run --host=0.0.0.0 --port=4567
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]
