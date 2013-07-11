// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


// access the namespaced object
var NERD = NERD || {};

// pass a reference to jquery and the namespace
(function($, APP){

    // DOM ready function
    $(function() {
        APP.TextBoxCounter.init();
    });

    /* -------------------------------------------------------------------------
    TextBoxCounter
    Author: Jen Heilemann

    Counts down the available characters before you reach the limit. Most
      browsers will do this themselves when you set a 'maxlength' value, but not
      all, so we create a fallback.

    Initial source:
    @link {www.mediacollege.com/internet/javascript/form/limit-characters.html}
    ------------------------------------------------------------------------- */
    APP.TextBoxCounter = {
        // jQuery selectors
        TEXTBOX: ".countdown",

        init: function() {
            var self = this;
            var $textbox = $(self.TEXTBOX);

            if ( $textbox.length > 0 ) {
                self.bind($textbox);
            }
        },

        bind: function($textbox) {
            var self = this;
            var max = $textbox.attr('maxlength');

            $textbox.after("<small>You have <strong class='counter'>"
                + max +
                "</strong> characters left.</small>");

            $textbox.keyup(function(){
                self.limitText($(this),$('.counter'),max)
            });
        },

        limitText: function($field, $counter, max) {
            if ($field.val().length > max) {
                $field.val($field.val().substring(0, max));
            } else {
                $counter.text(max - $field.val().length);
            }
        }
    }

}(jQuery, NERD));