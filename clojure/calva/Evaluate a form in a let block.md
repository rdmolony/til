In VSCode Calva, how do I evaluate any of the nested forms individually in

(let [router (ring/get-router app)] 
    (r/match-by-path router "/swagger.json")
    (r/match-by-path router "/v1/recipes/")
    (r/match-by-path router "/v1/recipes/1234-recipe"))

![[Evaluate a form in a let block.png]]

What I needed was `Evaluate From Start of Top Level Form to Cursor`
