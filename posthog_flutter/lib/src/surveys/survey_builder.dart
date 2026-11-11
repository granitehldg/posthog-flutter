import 'package:flutter/widgets.dart';

import 'models/posthog_display_survey.dart';
import 'models/survey_callbacks.dart';

/// Builds a custom survey UI in place of the default bottom sheet, or returns
/// `null` to show the default UI for this survey.
///
/// The widget is shown in the same modal bottom sheet the default UI uses.
/// Display conditions, branching, partial responses, seen state and survey
/// events are still handled by the SDK through [PostHogSurveyController].
typedef PostHogSurveyBuilder = Widget? Function(
  BuildContext context,
  PostHogSurveyController controller,
);

/// Connects a custom survey UI to the SDK.
///
/// Call [markShown] once the survey is visible, [submit] for each answered
/// question, and [close] when the user closes the survey.
class PostHogSurveyController {
  PostHogSurveyController({
    required this.survey,
    required OnSurveyShown onShown,
    required OnSurveyResponse onResponse,
    required void Function() onClose,
  })  : _onShown = onShown,
        _onResponse = onResponse,
        _onClose = onClose;

  /// The survey to render. Start at [PostHogDisplaySurvey.initialQuestionIndex],
  /// which is past 0 when the user is resuming a partial response.
  final PostHogDisplaySurvey survey;

  final OnSurveyShown _onShown;
  final OnSurveyResponse _onResponse;
  final void Function() _onClose;
  bool _shown = false;
  bool _closed = false;

  /// Records the `survey shown` event. Only the first call has an effect.
  void markShown() {
    if (_shown) return;
    _shown = true;
    _onShown(survey);
  }

  /// Submits the answer for the question at [questionIndex] and returns the
  /// question to show next, or `null` if the survey is no longer active.
  ///
  /// [response] is an `int?` for rating questions, a `List<String>?` for
  /// single and multiple choice questions (one entry for single choice),
  /// a `String` for open questions, and `true` for link questions. Pass
  /// `null` to skip an optional question.
  Future<PostHogSurveyNextQuestion?> submit(
    int questionIndex,
    Object? response,
  ) =>
      _onResponse(survey, questionIndex, response);

  /// Closes the survey. Closing before the last question records a dismissal.
  void close() {
    if (_closed) return;
    _closed = true;
    _onClose();
  }
}
