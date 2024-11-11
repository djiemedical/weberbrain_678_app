lib/
├── app.dart # App configuration and setup
├── main.dart # Entry point
│
├── config/
│ ├── routes/
│ │ ├── app_router.dart # Auto route configuration
│ │ └── app_router.gr.dart # Generated router code
│ └── themes/
│ └── app_theme.dart # Theme configuration
│
├── core/
│ ├── di/
│ │ └── injection_container.dart # Dependency injection setup
│ ├── error/
│ │ ├── exceptions.dart # Custom exceptions
│ │ └── failures.dart # Failure cases
│ ├── usecases/
│ │ ├── usecase.dart # Base usecase interface
│ │ └── params.dart # Common parameters
│ └── utils/
│ ├── constants.dart # App constants
│ └── extensions.dart # Extension methods
│
├── features/
│ ├── authentication/
│ │ ├── data/
│ │ │ ├── datasources/
│ │ │ │ ├── auth_local_data_source.dart
│ │ │ │ └── auth_remote_data_source.dart
│ │ │ ├── models/
│ │ │ │ └── user_model.dart
│ │ │ └── repositories/
│ │ │ └── auth_repository_impl.dart
│ │ ├── domain/
│ │ │ ├── entities/
│ │ │ │ └── user.dart
│ │ │ ├── repositories/
│ │ │ │ └── auth_repository.dart
│ │ │ └── usecases/
│ │ │ ├── login_usecase.dart
│ │ │ └── register_usecase.dart
│ │ └── presentation/
│ │ ├── bloc/
│ │ │ ├── auth_bloc.dart
│ │ │ ├── auth_event.dart
│ │ │ └── auth_state.dart
│ │ ├── pages/
│ │ │ ├── login_page.dart
│ │ │ └── register_page.dart
│ │ └── widgets/
│ │ ├── auth_form.dart
│ │ └── auth_button.dart
│ │
│ ├── my_device/
│ │ ├── data/
│ │ │ ├── datasources/
│ │ │ │ └── ble_device_data_source.dart
│ │ │ ├── models/
│ │ │ │ └── ble_device_model.dart
│ │ │ └── repositories/
│ │ │ └── my_device_repository_impl.dart
│ │ ├── domain/
│ │ │ ├── entities/
│ │ │ │ └── ble_device.dart
│ │ │ ├── repositories/
│ │ │ │ └── my_device_repository.dart
│ │ │ └── usecases/
│ │ │ ├── connect_device.dart
│ │ │ ├── disconnect_device.dart
│ │ │ └── scan_devices.dart
│ │ └── presentation/
│ │ ├── bloc/
│ │ │ ├── my_device_bloc.dart
│ │ │ ├── my_device_event.dart
│ │ │ └── my_device_state.dart
│ │ ├── pages/
│ │ │ └── my_device_page.dart
│ │ └── widgets/
│ │ ├── device_list.dart
│ │ └── device_card.dart
│ │
│ ├── session_timer/
│ │ ├── data/
│ │ │ ├── datasources/
│ │ │ │ └── timer_data_source.dart
│ │ │ └── repositories/
│ │ │ └── timer_repository_impl.dart
│ │ ├── domain/
│ │ │ ├── repositories/
│ │ │ │ └── timer_repository.dart
│ │ │ └── usecases/
│ │ │ └── start_timer.dart
│ │ └── presentation/
│ │ ├── bloc/
│ │ │ ├── session_timer_bloc.dart
│ │ │ ├── session_timer_event.dart
│ │ │ └── session_timer_state.dart
│ │ ├── pages/
│ │ │ └── session_timer_page.dart
│ │ └── widgets/
│ │ ├── circular_timer_display.dart
│ │ └── control_buttons.dart
│ │
│ └── settings/
│ ├── data/
│ │ ├── datasources/
│ │ │ └── settings_data_source.dart
│ │ └── repositories/
│ │ └── settings_repository_impl.dart
│ ├── domain/
│ │ ├── entities/
│ │ │ └── region_settings.dart
│ │ ├── repositories/
│ │ │ └── settings_repository.dart
│ │ └── usecases/
│ │ ├── get_frequency.dart
│ │ ├── get_output_power.dart
│ │ ├── get_regions.dart
│ │ ├── set_frequency.dart
│ │ └── set_output_power.dart
│ └── presentation/
│ ├── bloc/
│ │ ├── default_settings_bloc.dart
│ │ ├── default_settings_event.dart
│ │ └── default_settings_state.dart
│ ├── pages/
│ │ └── settings_page.dart
│ └── widgets/
│ └── default_settings_box.dart
│
test/
├── core/
│ └── usecases/
│ └── usecase_test.dart
│
├── features/
│ ├── authentication/
│ │ ├── data/
│ │ │ └── repositories/
│ │ │ └── auth_repository_impl_test.dart
│ │ └── domain/
│ │ └── usecases/
│ │ ├── login_usecase_test.dart
│ │ └── register_usecase_test.dart
│ │
│ ├── my_device/
│ │ ├── data/
│ │ │ └── repositories/
│ │ │ └── my_device_repository_impl_test.dart
│ │ └── domain/
│ │ └── usecases/
│ │ ├── connect_device_test.dart
│ │ └── scan_devices_test.dart
│ │
│ ├── session_timer/
│ │ └── presentation/
│ │ └── bloc/
│ │ └── session_timer_bloc_test.dart
│ │
│ └── settings/
│ ├── data/
│ │ └── repositories/
│ │ └── settings_repository_impl_test.dart
│ └── domain/
│ └── usecases/
│ ├── get_frequency_test.dart
│ └── set_output_power_test.dart
│
└── widget_test.dart
