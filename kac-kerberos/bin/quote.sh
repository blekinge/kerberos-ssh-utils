#!/usr/bin/env bash

#singlequite
printf "%q\n" "æøå aa \n adf   "

#doublequote
printf "%q\n" "$(printf '%q\n' 'zz aa \n adf   ')"