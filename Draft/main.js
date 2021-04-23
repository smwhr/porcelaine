(function(storyContent) {

    // Create ink story from the content using inkjs
    var story = new inkjs.Story(storyContent);

    var savePoint = "";

    let savedTheme;
    let globalTagTheme;

    // Global tags - those at the top of the ink file
    // We support:
    //  # theme: dark
    //  # author: Your Name
    var globalTags = story.globalTags;
    if( globalTags ) {
        for(var i=0; i<story.globalTags.length; i++) {
            var globalTag = story.globalTags[i];
            var splitTag = splitPropertyTag(globalTag);

            // THEME: dark
            if( splitTag && splitTag.property == "theme" ) {
                globalTagTheme = splitTag.val;
            }

            // author: Your Name
            else if( splitTag && splitTag.property == "author" ) {
                var byline = document.querySelector('.byline');
                byline.innerHTML = "by "+splitTag.val;
            }
        }
    }

    var storyContainer = document.querySelector('#story');
    var outerScrollContainer = document.querySelector('.outerContainer');

    // page features setup
    setupTheme();

    // Kick off the start of the story!
    continueStory(true);

    // Main story processing function. Each time this is called it generates
    // all the next content up as far as the next set of choices.
    function continueStory(firstTime) {

        var paragraphIndex = 0;
        var delay = 0.0;

        // Don't over-scroll past new content
        var previousBottomEdge = firstTime ? 0 : contentBottomEdgeY();

        // Generate story text - loop through available content
        var collectedParagraphs = [];
        var collectedDidascalies = [];

        while(story.canContinue) {

            // Get ink to generate the next paragraph
            var paragraphText = story.Continue();
            var tags = story.currentTags;

            if(tags.includes("didascalie")){
                collectedDidascalies.push(paragraphText)
            }else{
                collectedParagraphs.push(paragraphText)
            }

            

            // Create paragraph element (initially hidden)

        }

        let choices = story.currentChoices
                            .map(choice => {
                                const [choiceType, choiceValue] = choice.text.split(": ")
                                return {type: choiceType, value: choiceValue, choice}
                            })
        let envchoices = choices
                            .filter(({type}) => {
                                return type == "envchoice";
                            });
        let actchoices = choices
                            .filter(({type}) => {
                                return type == "actchoice";
                            });

        let nakedchoices = choices
                            .filter(({type}) => {
                                return type != "actchoice" && type != "envchoice";
                            })
                            .map( ({choice}) => ({
                                choice,
                                type: "naked",
                                value: choice.text,
                            }));

        storyContainer.innerHTML = "";
        collectedParagraphs
            .map(text => {
                let reenv = /<:([a-z_]*)>([^<]*)<\/>/g

                Array.from(text.matchAll(reenv)).forEach(([needle, key, innertext]) => {
                    let envchoice = envchoices.find(c => c.value == key);

                    if(typeof(envchoice) == "undefined"){
                        text = text.replace(needle, innertext);
                    }else{
                        text = text.replace(needle, 
                                    `<a href="#" class="choice envchoice" data-choice-index="${envchoice.choice.index}">${innertext}</a>`
                                    );
                    }
                })

                return text;

            })
            .map( text => {
                var paragraphElement = document.createElement('p')
                    paragraphElement.className = 'storyp';
                    paragraphElement.innerHTML = text;

                return paragraphElement;
            })
            .forEach(p => {
                storyContainer.appendChild(p)
            });

        collectedDidascalies
            .map( text => {
                var paragraphElement = document.createElement('p')
                    paragraphElement.className = 'storyp';
                    paragraphElement.innerHTML = `<em>${text}</em>`;

                return paragraphElement;
            })
            .forEach(p => {
                storyContainer.appendChild(p)
            });


        [... actchoices, ...nakedchoices]
            .map(({type, value: text, choice}) => {
                let paragraphElement = document.createElement('p');
                    paragraphElement.classList.add("choice");
                    paragraphElement.innerHTML = `<a href='#' class="choice" data-choice-index='${choice.index}'>${text}</a>`
                return paragraphElement;

            }).forEach(elt => storyContainer.appendChild(elt))


        storyContainer.querySelectorAll("a.choice")
                      .forEach( a => {
                            a.addEventListener("click", function(event){
                                event.preventDefault();
                                let index = parseInt(event.target.dataset.choiceIndex)
                                story.ChooseChoiceIndex(index);
                                removeAll(".choice:not(.envchoice)");
                                continueStory();
                            })
                })

        // Extend height to fit
        // We do this manually so that removing elements and creating new ones doesn't
        // cause the height (and therefore scroll) to jump backwards temporarily.
        storyContainer.style.height = contentBottomEdgeY()+"px";

        if( !firstTime )
            scrollDown(previousBottomEdge);

    }

    // -----------------------------------
    // Various Helper functions
    // -----------------------------------

    // Scrolls the page down, but no further than the bottom edge of what you could
    // see previously, so it doesn't go too far.
    function scrollDown(previousBottomEdge) {

        // Line up top of screen with the bottom of where the previous content ended
        var target = previousBottomEdge;

        // Can't go further than the very bottom of the page
        var limit = outerScrollContainer.scrollHeight - outerScrollContainer.clientHeight;
        if( target > limit ) target = limit;

        var start = outerScrollContainer.scrollTop;

        var dist = target - start;
        var duration = 300 + 300*dist/100;
        var startTime = null;
        function step(time) {
            if( startTime == null ) startTime = time;
            var t = (time-startTime) / duration;
            var lerp = 3*t*t - 2*t*t*t; // ease in/out
            outerScrollContainer.scrollTo(0, (1.0-lerp)*start + lerp*target);
            if( t < 1 ) requestAnimationFrame(step);
        }
        requestAnimationFrame(step);
    }

    // The Y coordinate of the bottom end of all the story content, used
    // for growing the container, and deciding how far to scroll.
    function contentBottomEdgeY() {
        var bottomElement = storyContainer.lastElementChild;
        return bottomElement ? bottomElement.offsetTop + bottomElement.offsetHeight : 0;
    }

    // Remove all elements that match the given selector. Used for removing choices after
    // you've picked one, as well as for the CLEAR and RESTART tags.
    function removeAll(selector)
    {
        var allElements = storyContainer.querySelectorAll(selector);
        for(var i=0; i<allElements.length; i++) {
            var el = allElements[i];
            el.parentNode.removeChild(el);
        }
    }

    // Used for hiding and showing the header when you CLEAR or RESTART the story respectively.
    function setVisible(selector, visible)
    {
        var allElements = storyContainer.querySelectorAll(selector);
        for(var i=0; i<allElements.length; i++) {
            var el = allElements[i];
            if( !visible )
                el.classList.add("invisible");
            else
                el.classList.remove("invisible");
        }
    }

    // Helper for parsing out tags of the form:
    //  # PROPERTY: value
    // e.g. IMAGE: source path
    function splitPropertyTag(tag) {
        var propertySplitIdx = tag.indexOf(":");
        if( propertySplitIdx != null ) {
            var property = tag.substr(0, propertySplitIdx).trim();
            var val = tag.substr(propertySplitIdx+1).trim();
            return {
                property: property,
                val: val
            };
        }

        return null;
    }

    // Loads save state if exists in the browser memory
    function loadSavePoint() {

        try {
            let savedState = window.localStorage.getItem('save-state');
            if (savedState) {
                story.state.LoadJson(savedState);
                return true;
            }
        } catch (e) {
            console.debug("Couldn't load save state");
        }
        return false;
    }

    // Detects which theme (light or dark) to use
    function setupTheme() {

        // Check whether the OS/browser is configured for dark mode
        var browserDark = window.matchMedia("(prefers-color-scheme: dark)").matches;

        if (browserDark)
            document.body.classList.add("dark");
    }

    // Used to hook up the functionality for global functionality buttons
    function setupButtons(hasSave) {

        let rewindEl = document.getElementById("rewind");
        if (rewindEl) rewindEl.addEventListener("click", function(event) {
            removeAll("p");
            removeAll("img");
            setVisible(".header", false);
            restart();
        });

        let saveEl = document.getElementById("save");
        if (saveEl) saveEl.addEventListener("click", function(event) {
            try {
                window.localStorage.setItem('save-state', savePoint);
                document.getElementById("reload").removeAttribute("disabled");
                window.localStorage.setItem('theme', document.body.classList.contains("dark") ? "dark" : "");
            } catch (e) {
                console.warn("Couldn't save state");
            }

        });

        
    }

})(storyContent);
