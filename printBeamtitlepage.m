## Copyright (C) 2022 ggend
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {} {@var{retval} =} printBeamtitlepage (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: ggend <ggend@DESKTOP-9UCS2EH>
## Created: 2022-06-11

function printBeamtitlepage (fid, Title, Date)
fprintf(fid,"\\title\{%s\}\n",Title);
fprintf(fid,"\\subtitle\{%s\}\n",Date);
fprintf(fid,"\\author\{Guy Gendron, ing., Ph.D.\}\n");
fprintf(fid,"\\date\{\\today\}\n");
fprintf(fid,"\\begin{frame}\n");
fprintf(fid,"\\titlepage\n");
fprintf(fid,"\\end{frame}\n");
endfunction
