%hook RTTUIUtteranceCell
	- (void)_accessibilityHandleATFocused:(BOOL)arg1 assistiveTech:(id)arg2 {
		%orig;
		Log(@"- (void)_accessibilityHandleATFocused:(BOOL)arg1 assistiveTech:(id)arg2;");
	}
	- (void)textViewDidChange:(id)arg1 {
		%orig;
		Log(@"- (void)textViewDidChange:(id)arg1;");
	}
	- (void)layoutSubviews {
		%orig;
		Log(@"- (void)layoutSubviews;");
	}
	- (void)updateLayout {
		%orig;
		Log(@"- (void)updateLayout;");
	}
	- (void)adjustTextViewSize {
		%orig;
		Log(@"- (void)adjustTextViewSize;");
	}
	- (void)setHighlighted:(BOOL)arg1 animated:(BOOL)arg2 {
		%orig;
		Log(@"- (void)setHighlighted:(BOOL)arg1 animated:(BOOL)arg2;");
	}
	- (void)setSelected:(BOOL)arg1 animated:(BOOL)arg2 {
		%orig;
		Log(@"- (void)setSelected:(BOOL)arg1 animated:(BOOL)arg2;");
	}
	- (void)dealloc {
		%orig;
		Log(@"- (void)dealloc;");
	}
	- (void)setSendProgressIndex:(NSUInteger)arg1 {
		%orig;
		Log(@"- (void)setSendProgressIndex:(NSUInteger)arg1;");
	}
	- (void)updateUtterance:(id)arg1 {
		%orig;
		Log(@"- (void)updateUtterance:(id)arg1;");
	}
	- (void)updateUtterance:(id)arg1 postNotifications:(BOOL)arg2 {
		%orig;
		Log(@"- (void)updateUtterance:(id)arg1 postNotifications:(BOOL)arg2;");
	}
%end

%hook CSUtteranceMetadataManager
	+ (void)_upgradeUtteranceMeta:(id)arg1 {
		%orig;
		Log(@"+ (void)_upgradeUtteranceMeta:(id)arg1;");
	}
	+ (void)_upgradeLocaleDirectoryIfNecessary:(id)arg1 {
		%orig;
		Log(@"+ (void)_upgradeLocaleDirectoryIfNecessary:(id)arg1;");
	}
	+ (void)_saveMetaVersionFileAtPath:(id)arg1 {
		%orig;
		Log(@"+ (void)_saveMetaVersionFileAtPath:(id)arg1;");
	}
	+ (void)upgradeMetaFilesIfNecessaaryAtSATRoot:(id)arg1 {
		%orig;
		Log(@"+ (void)upgradeMetaFilesIfNecessaaryAtSATRoot:(id)arg1;");
	}
	+ (void)saveMetaVersionFileAtSATAudioDirectory:(id)arg1 {
		%orig;
		Log(@"+ (void)saveMetaVersionFileAtSATAudioDirectory:(id)arg1;");
	}
	+ (void)_writeMetaDict:(id)arg1 forUtterancePath:(id)arg2 {
		%orig;
		Log(@"+ (void)_writeMetaDict:(id)arg1 forUtterancePath:(id)arg2;");
	}
	+ (void)saveUtteranceMetadataForUtterance:(id)arg1 enrollmentType:(id)arg2 isHandheldEnrollment:(BOOL)arg3 triggerSource:(id)arg4 audioInput:(id)arg5 otherBiometricResult:(NSUInteger)arg6 containsPayload:(BOOL)arg7 {
		%orig;
		Log(@"+ (void)saveUtteranceMetadataForUtterance:(id)arg1 enrollmentType:(id)arg2 isHandheldEnrollment:(BOOL)arg3 triggerSource:(id)arg4 audioInput:(id)arg5 otherBiometricResult:(NSUInteger)arg6 containsPayload:(BOOL)arg7;");
	}
%end

%hook RTTUtterance
	- (void)resetTimeout {
		%orig;
		Log(@"- (void)resetTimeout;");
	}
	- (void)updateText:(id)arg1 {
		%orig;
		Log(@"- (void)updateText:(id)arg1;");
	}
	- (void)dealloc {
		%orig;
		Log(@"- (void)dealloc;");
	}
	- (void)encodeWithCoder:(id)arg1 {
		%orig;
		Log(@"- (void)encodeWithCoder:(id)arg1;");
	}
%end

%hook SAUIAssistantUtteranceView
	- (void)af_addEntriesToAnalyticsContext:(id)arg1 {
		%orig;
		Log(@"- (void)af_addEntriesToAnalyticsContext:(id)arg1;");
	}
%end

%hook AFUtteranceSuggestions
	- (void)setSuggestedUtterances:(id)arg1 {
		%orig;
		Log(@"- (void)setSuggestedUtterances:(id)arg1;");
	}
	- (void)getSuggestedUtterancesWithCompletion:(id /* CDUnknownBlockType */)arg1 {
		%orig;
		Log(@"- (void)getSuggestedUtterancesWithCompletion:(id /* CDUnknownBlockType */)arg1;");
	}
%end

%hook AFUserUtteranceSelectionResults
	- (void)encodeWithCoder:(id)arg1 {
		%orig;
		Log(@"- (void)encodeWithCoder:(id)arg1;");
	}
%end

%hook AFSpeechUtterance
	- (void)encodeWithCoder:(id)arg1 {
		%orig;
		Log(@"- (void)encodeWithCoder:(id)arg1;");
	}
%end

%hook AFSpeakableUtteranceParser
	- (void)registerProvider:(id)arg1 forNamespace:(id)arg2 {
		%orig;
		Log(@"- (void)registerProvider:(id)arg1 forNamespace:(id)arg2;");
	}
%end

%hook AFUserUtterance
	- (void)_updateUtteranceswithAlternativeUtteranceAtIndex:(NSUInteger)arg1 swapIndices:(id)arg2 {
		%orig;
		Log(@"- (void)_updateUtteranceswithAlternativeUtteranceAtIndex:(NSUInteger)arg1 swapIndices:(id)arg2;");
	}
	- (void)_updatePhraseswithSwapIndices:(id)arg1 {
		%orig;
		Log(@"- (void)_updatePhraseswithSwapIndices:(id)arg1;");
	}
%end

