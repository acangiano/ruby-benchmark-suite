var submitting = false;
function doSubmit() {
	if (submitting == true) {
		return;
	}
	var theButton = document.getElementById("submitButton");
	theButton.style.display = "none";
	var info = document.getElementById("submittingText");
	info.style.display = "block";

	var submitting="true";
	// submit the form
	document.getElementById("theForm").submit();
}

/**
 * Shows warning before taking action - used for delete.
 */
function doSubmitWarning(theFormId) {
	if (submitting == true) {
		return;
	}
	var doSubmit = confirm("Are you REALLY sure you want to delete this order?\n\nYou can NEVER get it back!");
	if (doSubmit == true) {
		var submitting="true";
		// submit the form
		document.getElementById(theFormId).submit();
	}
}

/**
 * Order form initialization.
 */
function initOrderForm() {
	var box = $("use_diff_shipping");
	if (box) {
		addEvent(box, "focus", toggleShippingAddress);
		addEvent(box, "click", toggleShippingAddress);
	}
}
Event.observe(window, 'load', initOrderForm, false);

/**
 * Toggles the display of shipping address
 */
function toggleShippingAddress(e) {
	var shipBlock = $("shipping_address");
	var box = $("use_diff_shipping");
	if (shipBlock != null && box != null) {
		if (box.checked == true) {
			shipBlock.style.display = "block";
		} else {
			shipBlock.style.display = "none";
		}
	}
}
