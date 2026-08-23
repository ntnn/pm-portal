FROM node:24.19@sha256:934240a162082fd8b8a2f90cd5114446443f1eba1c5378f6687167ca405e6584 AS build

COPY frontend/package.json frontend/build-scripts/extract-versions.js frontend/package-lock.json /app/frontend/
COPY backend/package.json backend/package-lock.json /app/backend/
COPY package.json package-lock.json /app/

WORKDIR /app
RUN npm ci

COPY . ./

RUN npm run build

FROM node:24.19.0-alpine@sha256:d32cdf619f63fe0471182d08996dd516c6275bb5fd31ae06e55a570bd9e1ad43

ENV USER_UID=1001
ENV GROUP_UID=1001

COPY --from=build --chown=${USER_UID}:${GROUP_UID} /app/backend /app/backend
COPY --from=build --chown=${USER_UID}:${GROUP_UID} /app/frontend/dist /app/frontend/dist

WORKDIR /app/backend
EXPOSE 3000
USER ${USER_UID}:${GROUP_UID}
CMD ["node", "dist/main"]
