"VIM syntax script

if !exists("main_syntax")
  if exists("b:current_syntax")
    finish
  endif
endif
let main_syntax = 'pymol'

set iskeyword=@,48-57,_,192-255,.

syntax match   pymolIdentifier "[a-zA-Z0-9().]"
syntax keyword pymolCommand    load load_traj save delete quit turn move clip rock show hide enable disable reset refresh rebuild zoom origin orient view get_view set_view mplay mstop mset mdo mpng mmatrix frame rewind middle ending forward backward png mpng ray isomesh isodot isosurface cls viewport splash select mask set button alter alter_state create replace remove h_fill remove_picked edit bond unbond h_add fuse undo redo protect cycle_valence attach fit rms rms_cur pair_fit intra_fit intra_rms intra_rms_cur color set_color help commands dist stereo symexp @ run alias extend load save delete quit turn move clip rock show hide enable disable reset refresh rebuild zoom origin orient view get_view set_view mplay mstop mset mdo mpng mmatrix frame rewind middle ending forward backward png mpng ray isomesh isodot cls viewport splash select mask set button alter alter_state create replace remove h_fill remove_picked edit bond unbond h_add fuse undo redo protect cycle_valence attach fit rms rms_cur pair_fit intra_fit intra_rms intra_rms_cur color set_color help commands dist stereo symexp @ run alias extend rotate alignto

syntax match   pymolOperator1   "[!|&,()?]"
syntax match   pymolOperator2   "([|aew].)|(b[rfmso].)|(nbr.)|([?][?][?])"
syntax keyword pymolOperatorK   and or not in gap around within of byres bymolecule byfragment bysegment byobject bycell neighbor extend
syntax cluster pymolOperator    contains=pymolOperator1,pymolOperator2,pymolOperatorK
syntax keyword pymolSelector    resi resn name alt chain segi flag numeric_type text_type id index ss b q formal_charge partial_charge
syntax match   pymolComment     "^#.*$"
syntax match   pymolNumber      "*[0-9](.[0-9])?"
syntax match   pymolString1     "'[^']*'"
syntax match   pymolString2     '"[^"]*"'
syntax cluster pymolString      contains=pymolString1,pymolString2
syntax match   pymolIdentifier  "[A-Za-z_][A-Za-z_.0-9()]*"
syntax match   pymolPunctuation "[(),]"

hi def link    pymolCommand     Statement
hi def link    pymolIdentifier  Symbol
hi def link    pymolOperator    Operator
hi def link    pymolComment     Comment
hi def link    pymolString      String
hi def link    pymolSelector    Function
hi def link    pymolPunctuation SpecialChar

