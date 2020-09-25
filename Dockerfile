# Dockerfile for gcr.io/tensorflow-system-libraries/sdl-demo
FROM gcr.io/bazel-public/ubuntu1604-bazel-java8@sha256:028489c090b9225290499a8015ba0179bb3e5ba6b0d0aa5b192237fe0dd8de55

RUN \
    apt-get update && \
    apt-get -y install \
	libgif-dev \
	libpng-dev \
	libjpeg-dev \
    libz-dev \
    libsdl2-image-dev \
    libsdl2-dev
