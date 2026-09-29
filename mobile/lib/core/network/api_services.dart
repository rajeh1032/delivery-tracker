import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import '../../features/delivery/data_sources/models/request/complete_delivery_request_dto.dart';
import '../../features/delivery/data_sources/models/request/fail_delivery_request_dto.dart';
import '../../features/delivery/data_sources/models/response/delivery_response_dto.dart';
import 'network_constants.dart';

part 'api_services.g.dart';

/// Retrofit REST API service client defining delivery tracking endpoints.
@RestApi()
@injectable
abstract class ApiServices {
  @factoryMethod
  factory ApiServices(Dio dio) = _ApiServices;

  @GET(NetworkConstants.pathDeliveries)
  Future<List<DeliveryResponseDto>> getDeliveries();

  @GET(NetworkConstants.pathDeliveryById)
  Future<DeliveryResponseDto> getDeliveryById(
    @Path(NetworkConstants.paramId) int id,
  );

  @POST(NetworkConstants.pathCompleteDelivery)
  Future<DeliveryActionResponseDto> completeDelivery(
    @Path(NetworkConstants.paramId) int id,
    @Body() CompleteDeliveryRequestDto request,
  );

  @POST(NetworkConstants.pathFailDelivery)
  Future<DeliveryActionResponseDto> failDelivery(
    @Path(NetworkConstants.paramId) int id,
    @Body() FailDeliveryRequestDto request,
  );

  @POST(NetworkConstants.pathUploadProof)
  @MultiPart()
  Future<ProofUploadResponseDto> uploadProof(
    @Path(NetworkConstants.paramId) int id,
    @Part(name: NetworkConstants.paramPhoto) File photo,
  );
}
