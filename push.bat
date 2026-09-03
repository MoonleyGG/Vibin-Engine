@echo off
set /p commitThing="Enter commit message: "

git add .
git commit -m "%commitThing%"
git push origin main