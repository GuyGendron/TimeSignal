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
## @deftypefn {} {@var{retval} =} printtopresultfile (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: ggend <ggend@DESKTOP-9UCS2EH>
## Created: 2022-06-08

function printtopresultfile (fid,Title,Date)
fprintf(fid,"\\documentclass[10pt]{beamer}\n");
fprintf(fid,"\\usepackage{amsmath}\n");
fprintf(fid,"\\usepackage{graphicx}\n");
fprintf(fid,"\\usepackage{verbatim}\n");
fprintf(fid,"\\usepackage{color}\n");
fprintf(fid,"\\usepackage{subfigure}\n");
fprintf(fid,"\\usepackage{hyperref}\n");
fprintf(fid,"\\usetheme{CambridgeUS}\n");
fprintf(fid,"\\usepackage[utf8]{inputenc}\n");
fprintf(fid,"\\usepackage[T1]{fontenc}\n");
fprintf(fid,"\\definecolor{SimuXpertBlue}{RGB}{29,111,167}\n");
fprintf(fid,"\\definecolor{SimuXpertOrange}{RGB}{246,117,16}\n");
fprintf(fid,"\\definecolor{SimuXpertGrey}{RGB}{109,119,122}\n");
fprintf(fid,"\\setbeamercolor{palette primary}{bg=SimuXpertOrange,fg=white}\n");
fprintf(fid,"\\setbeamercolor{palette secondary}{bg=SimuXpertOrange,fg=white}\n");
fprintf(fid,"\\setbeamercolor{palette tertiary}{bg=SimuXpertOrange,fg=white}\n");
fprintf(fid,"\\setbeamercolor{palette quaternary}{bg=SimuXpertOrange,fg=white}\n");
fprintf(fid,"\\setbeamercolor{structure}{fg=SimuXpertBlue}\n"); % itemize, enumerate, etc
fprintf(fid,"\\setbeamercolor{section in toc}{fg=SimuXpertBlue}\n"); % TOC sections
fprintf(fid,"\\setbeamercolor{frametitle}{bg=SimuXpertGrey,fg=white}\n");
fprintf(fid,"\\setbeamercolor{subsection in head/foot}{bg=SimuXpertOrange,fg=white}\n");
fprintf(fid,"\\setbeamercolor{section in head/foot}{bg=SimuXpertOrange,fg=white}\n");

%
%fprintf(fid,"\\setbeamerfont{section title}{parent=title}\n");
%fprintf(fid,"\\setbeamercolor\{section title\}\{parent=titlelike\}\n");
%fprintf(fid,"\\defbeamertemplate*\{section page\}\{default\}\[1\]\[\]\n");
%fprintf(fid,"\{\n");
%fprintf(fid,"\\centering\n");
%fprintf(fid,"\\begin{beamercolorbox}[sep=8pt,center,#1]{section title}\n");
%fprintf(fid,"\\usebeamerfont{section title}\insertsection\par\n");
%fprintf(fid,"\\end{beamercolorbox}\n");
%fprintf(fid,"\}\n");
%fprintf(fid,"\\newcommand\*\{\\sectionpage\}\{\\usebeamertemplate\*\{section page\}\}\n");
%
fprintf(fid,"\\begin{document}\n");
fprintf(fid,"\\title\{%s\}\n",Title);
fprintf(fid,"\\subtitle\{%s\}\n",Date);
fprintf(fid,"\\author\{Guy Gendron, ing., Ph.D.\}\n");
fprintf(fid,"\\date\{\\today\}\n");
fprintf(fid,"\\begin{frame}\n");
fprintf(fid,"\\titlepage\n");
fprintf(fid,"\\end{frame}\n");
fprintf(fid,"\\begin{frame}[allowframebreaks]{Outline}\n");
fprintf(fid,"\\tableofcontents\n");
fprintf(fid,"\\end{frame}\n");
endfunction
