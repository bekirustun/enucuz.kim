#!/bin/bash
pnpm --filter \"apps/web\" dev &
pnpm --filter \"apps/admin\" dev &
