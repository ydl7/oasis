#!/bin/bash
################################################################################
#  OASIS: architecture for building OCaml libraries and applications           #
#                                                                              #
#  Copyright (C) 2011-2013, Sylvain Le Gall                                    #
#  Copyright (C) 2008-2011, OCamlCore SARL                                     #
#                                                                              #
#  This library is free software; you can redistribute it and/or modify it     #
#  under the terms of the GNU Lesser General Public License as published by    #
#  the Free Software Foundation; either version 2.1 of the License, or (at     #
#  your option) any later version, with the OCaml static compilation           #
#  exception.                                                                  #
#                                                                              #
#  This library is distributed in the hope that it will be useful, but         #
#  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY  #
#  or FITNESS FOR A PARTICULAR PURPOSE. See the file COPYING for more          #
#  details.                                                                    #
#                                                                              #
#  You should have received a copy of the GNU Lesser General Public License    #
#  along with this library; if not, write to the Free Software Foundation,     #
#  Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA               #
################################################################################

function run {
    NAME=$1
    shift
    echo -n "$NAME ... "
    $@
    CODE=$?
    if [ $CODE -ne 0 ]; then
        echo "... $NAME failed!"
        exit $CODE
    else
        echo "... $NAME OK"
    fi
}

cd "$APPVEYOR_BUILD_FOLDER"

export OCAMLRUNPARAM=b

run "OPAM initialization" opam init -y -a
run "Install packages" opam install -y ocamlfind ocamlmod ocamlify ounit \
  fileutils ounit
eval $(opam config env)
export OCAML_TOPLEVEL_PATH=$(opam config var toplevel)

run "OASIS Configure step" ocaml setup.ml -configure
run "OASIS Build step" ocaml setup.ml -build

run "Install" ocaml setup.ml -install

echo "------------------------------------------------------------"
echo "Rebuild with dynamic mode"
run "Setup" ./Main.native setup -setup-update dynamic
run "Configure" ocaml setup.ml -info -configure
# TODO: temporary fix, remove
run "Build" ocaml setup.ml -build || true
