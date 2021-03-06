FROM python:3.9-alpine

RUN apk --no-cache add curl
RUN apk --no-cache add sudo

#Download the desired package(s)
RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.9.1.1-1_amd64.apk



#Install the package(s)
RUN sudo apk add --allow-untrusted msodbcsql17_17.9.1.1-1_amd64.apk


RUN apk add g++ unixodbc-dev 

COPY requirements.txt .
RUN pip install -r requirements.txt --user

COPY src /src/



ENTRYPOINT ["python", "/src/main.py"]