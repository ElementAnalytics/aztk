# Open JDK JRE only on alpine 3.8
FROM elementanalytics/openjdk8:element_checksum_f7582d2716066ab7d1faeed281716689099bbdb4 AS builder

COPY config /assets
RUN /assets/docker-install.sh

CMD ["/bin/bash"]

#
# runtime image
FROM elementanalytics/openjdk8:element_checksum_f7582d2716066ab7d1faeed281716689099bbdb4 AS runtime

COPY --from=builder /home /home
RUN apk --no-cache add bash

CMD ["/bin/bash"]
