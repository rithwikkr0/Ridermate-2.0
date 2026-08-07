/// RiderMate 2.0 — Medical Profile Model
class MedicalProfileModel {
  final String bloodGroup;
  final List<String> allergies;
  final List<String> medicalConditions;
  final String emergencyNotes;
  final String insuranceProvider;
  final String insurancePolicyNumber;
  final String doctorContactPhone;

  const MedicalProfileModel({
    required this.bloodGroup,
    required this.allergies,
    required this.medicalConditions,
    required this.emergencyNotes,
    required this.insuranceProvider,
    required this.insurancePolicyNumber,
    required this.doctorContactPhone,
  });
}
