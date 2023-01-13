let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.7.3-20221102/package-set.dhall sha256:9c989bdc496cf03b7d2b976d5bf547cfc6125f8d9bb2ed784815191bd518a7b9
let Package =
    { name : Text, version : Text, repo : Text, dependencies : List Text }

let
  -- This is where you can add your own packages to the package-set
  additions =
    [
      { name = "candy"
      , version = "v0.1.13"
      , repo = "https://github.com/aramakme/candy_library.git"
      , dependencies = ["base"] : List Text
      },
      { name = "candid_stringify"
      , version = "v0.0.1"
      , repo = "https://github.com/ORIGYN-SA/candid_stringify"
      , dependencies = ["base",  "xtended-numbers", "itertools"] : List Text
      },
      { 
        name = "candid", 
        version = "main", 
        repo = "https://github.com/gekctek/motoko_candid", 
        dependencies = [] : List Text
      },
      { 
        name = "itertools", 
        version = "master", 
        repo = "https://github.com/NatLabs/Itertools", 
        dependencies = [] : List Text
      },
      { 
        name = "xtended-numbers", 
        version = "v1.0.0", 
        repo = "https://github.com/gekctek/motoko_numbers", 
        dependencies = [] : List Text
      }
     
    ] : List Package

let
  {- This is where you can override existing packages in the package-set

     For example, if you wanted to use version `v2.0.0` of the foo library:
     let overrides = [
         { name = "foo"
         , version = "v2.0.0"
         , repo = "https://github.com/bar/foo"
         , dependencies = [] : List Text
         }
     ]
  -}
  overrides =
    [] : List Package

in  upstream # additions # overrides
