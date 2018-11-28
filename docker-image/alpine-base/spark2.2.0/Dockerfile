# Open JDK JRE only on alpine 3.8
FROM elementanalytics/openjdk8:element_checksum_64f14af9bf0ad266024c08b6f6376e7986651520 AS builder

COPY config /assets
RUN /assets/docker-install.sh

CMD ["/bin/bash"]

#
# runtime image
FROM elementanalytics/openjdk8:element_checksum_64f14af9bf0ad266024c08b6f6376e7986651520 AS runtime

COPY --from=builder /home /home
RUN apk --no-cache add bash

CMD ["/bin/bash"]
