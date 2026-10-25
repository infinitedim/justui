import '../scene.dart';
import 'date_picker_scene.dart';
import 'date_range_picker_scene.dart';
import 'input_scene.dart';
import 'radio_group_scene.dart';
import 'slider_scene.dart';
import 'switch_scene.dart';

/// Scenes of the v3 "Inputs" group.
///
/// `radio` and `radio-group` share one demo, as they share the React
/// `radios` renderer in `KitPart`.
const Map<String, SceneBuilder> inputsScenes = <String, SceneBuilder>{
  'input': inputScene,
  'radio': radioGroupScene,
  'radio-group': radioGroupScene,
  'switch': switchScene,
  'slider': sliderScene,
  'date-picker': datePickerScene,
  'date-range-picker': dateRangePickerScene,
};
