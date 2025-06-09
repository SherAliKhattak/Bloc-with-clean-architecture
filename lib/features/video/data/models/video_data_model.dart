class Video {
  int? id;
  String? title;
  String? url;
  String? cdnUrl;
  String? thumbCdnUrl;
  int? userId;
  String? status;
  String? slug;
  String? encodeStatus;
  int? priority;
  int? categoryId;
  int? totalViews;
  int? totalLikes;
  int? totalComments;
  int? totalShare;
  int? totalWishlist;
  int? duration;
  DateTime? byteAddedOn;
  DateTime? byteUpdatedOn;
  String? bunnyStreamVideoId;
  String? bytePlusVideoId;
  String? language;
  String? orientation;
  int? bunnyEncodingStatus;
  String? deletedAt;
  int? videoHeight;
  int? videoWidth;
  String? location;
  int? isPrivate;
  int? isHideComment;
  String? description;
  String? archivedAt;
  String? latitude;
  String? longitude;
  User? user;
  Category? category;
  List<dynamic>? resolutions;
  bool? isLiked;
  bool? isWished;
  bool? isFollow;
  String? metaDescription;
  String? metaKeywords;
  String? videoAspectRatio;

  Video({
    this.id,
    this.title,
    this.url,
    this.cdnUrl,
    this.thumbCdnUrl,
    this.userId,
    this.status,
    this.slug,
    this.encodeStatus,
    this.priority,
    this.categoryId,
    this.totalViews,
    this.totalLikes,
    this.totalComments,
    this.totalShare,
    this.totalWishlist,
    this.duration,
    this.byteAddedOn,
    this.byteUpdatedOn,
    this.bunnyStreamVideoId,
    this.bytePlusVideoId,
    this.language,
    this.orientation,
    this.bunnyEncodingStatus,
    this.deletedAt,
    this.videoHeight,
    this.videoWidth,
    this.location,
    this.isPrivate,
    this.isHideComment,
    this.description,
    this.archivedAt,
    this.latitude,
    this.longitude,
    this.user,
    this.category,
    this.resolutions,
    this.isLiked,
    this.isWished,
    this.isFollow,
    this.metaDescription,
    this.metaKeywords,
    this.videoAspectRatio,
  });

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        id: json.containsKey('id') ? json['id'] : 0,
        title: json.containsKey('title') ? json['title'].toString() : "",
        url: json.containsKey('url') ? json['url'].toString() : "",
        cdnUrl: json.containsKey('cdn_url') ? json['cdn_url'].toString() : "",
        thumbCdnUrl: json.containsKey('thumb_cdn_url')
            ? json['thumb_cdn_url'].toString()
            : "",
        userId: json.containsKey('user_id') ? json['user_id'] : 0,
        status: json.containsKey('status') ? json['status'].toString() : "",
        slug: json.containsKey('slug') ? json['slug'].toString() : "",
        encodeStatus: json.containsKey('encode_status')
            ? json['encode_status'].toString()
            : "",
        priority: json.containsKey('priority') ? json['priority'] as int : 0,
        categoryId: json.containsKey('category_id') ? json['category_id'] : 0,
        totalViews:
            json.containsKey('total_views') ? json['total_views'] as int : 0,
        totalLikes:
            json.containsKey('total_likes') ? json['total_likes'] as int : 0,
        totalComments: json.containsKey('total_comments')
            ? json['total_comments'] as int
            : 0,
        totalShare:
            json.containsKey('total_share') ? json['total_share'] as int : 0,
        totalWishlist: json.containsKey('total_wishlist')
            ? json['total_wishlist'] as int
            : 0,
        duration: json.containsKey('duration') ? json['duration'] : 0,
        byteAddedOn:
            json.containsKey('byte_added_on') && json['byte_added_on'] != null
                ? DateTime.tryParse(json['byte_added_on'])
                : null,
        byteUpdatedOn: json.containsKey('byte_updated_on') &&
                json['byte_updated_on'] != null
            ? DateTime.tryParse(json['byte_updated_on'])
            : null,
        bunnyStreamVideoId: json.containsKey('bunny_stream_video_id')
            ? json['bunny_stream_video_id'].toString()
            : "",
        bytePlusVideoId: json.containsKey('byte_plus_video_id')
            ? json['byte_plus_video_id'].toString()
            : "",
        language:
            json.containsKey('language') ? json['language'].toString() : "",
        orientation: json.containsKey('orientation')
            ? json['orientation'].toString()
            : "",
        bunnyEncodingStatus: json.containsKey('bunny_encoding_status')
            ? json['bunny_encoding_status']
            : 0,
        deletedAt:
            json.containsKey('deleted_at') ? json['deleted_at'].toString() : "",
        videoHeight:
            json.containsKey('video_height') ? json['video_height'] as int : 0,
        videoWidth:
            json.containsKey('video_width') ? json['video_width'] as int : 0,
        location:
            json.containsKey('location') ? json['location'].toString() : "",
        isPrivate: json.containsKey('is_private') ? json['is_private'] : false,
        isHideComment: json.containsKey('is_hide_comment')
            ? json['is_hide_comment']
            : false,
        description: json.containsKey('description')
            ? json['description'].toString()
            : "",
        archivedAt: json.containsKey('archived_at')
            ? json['archived_at'].toString()
            : "",
        latitude: json.containsKey('latitude') ? json['latitude'] : 0.0,
        longitude: json.containsKey('longitude') ? json['longitude'] : 0.0,
        user: json.containsKey('user') && json['user'] != null
            ? User.fromJson(json['user'])
            : null,
        category: json.containsKey('category') && json['category'] != null
            ? Category.fromJson(json['category'])
            : null,
        resolutions: json.containsKey('resolutions') ? json['resolutions'] : "",
        isLiked:
            json.containsKey('is_liked') ? json['is_liked'] as bool : false,
        isWished:
            json.containsKey('is_wished') ? json['is_wished'] as bool : false,
        isFollow:
            json.containsKey('is_follow') ? json['is_follow'] as bool : false,
        metaDescription: json.containsKey('meta_description')
            ? json['meta_description'].toString()
            : "",
        metaKeywords: json.containsKey('meta_keywords')
            ? json['meta_keywords'].toString()
            : "",
        videoAspectRatio: json.containsKey('video_aspect_ratio')
            ? json['video_aspect_ratio'].toString()
            : "",
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'url': url,
        'cdn_url': cdnUrl,
        'thumb_cdn_url': thumbCdnUrl,
        'user_id': userId,
        'status': status,
        'slug': slug,
        'encode_status': encodeStatus,
        'priority': priority,
        'category_id': categoryId,
        'total_views': totalViews,
        'total_likes': totalLikes,
        'total_comments': totalComments,
        'total_share': totalShare,
        'total_wishlist': totalWishlist,
        'duration': duration,
        'byte_added_on': byteAddedOn?.toIso8601String(),
        'byte_updated_on': byteUpdatedOn?.toIso8601String(),
        'bunny_stream_video_id': bunnyStreamVideoId,
        'byte_plus_video_id': bytePlusVideoId,
        'language': language,
        'orientation': orientation,
        'bunny_encoding_status': bunnyEncodingStatus,
        'deleted_at': deletedAt,
        'video_height': videoHeight,
        'video_width': videoWidth,
        'location': location,
        'is_private': isPrivate,
        'is_hide_comment': isHideComment,
        'description': description,
        'archived_at': archivedAt,
        'latitude': latitude,
        'longitude': longitude,
        'user': user?.toJson(),
        'category': category?.toJson(),
        'resolutions': resolutions,
        'is_liked': isLiked,
        'is_wished': isWished,
        'is_follow': isFollow,
        'meta_description': metaDescription,
        'meta_keywords': metaKeywords,
        'video_aspect_ratio': videoAspectRatio,
      };
}

class User {
  int? userId;
  String? fullname;
  String? username;
  String? profilePicture;
  String? profilePictureCdn;
  String? designation;
  bool? isSubscriptionActive;
  bool? isFollow;

  User({
    this.userId,
    this.fullname,
    this.username,
    this.profilePicture,
    this.profilePictureCdn,
    this.designation,
    this.isSubscriptionActive,
    this.isFollow,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json.containsKey('user_id') ? json['user_id'] : "",
        fullname:
            json.containsKey('fullname') ? json['fullname'].toString() : "",
        username:
            json.containsKey('username') ? json['username'].toString() : "",
        profilePicture: json.containsKey('profile_picture')
            ? json['profile_picture'].toString()
            : "",
        profilePictureCdn: json.containsKey('profile_picture_cdn')
            ? json['profile_picture_cdn'].toString()
            : "",
        designation: json.containsKey('designation')
            ? json['designation'].toString()
            : "",
        isSubscriptionActive: json.containsKey('is_subscription_active')
            ? json['is_subscription_active'] as bool
            : false,
        isFollow:
            json.containsKey('is_follow') ? json['is_follow'] as bool : false,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'fullname': fullname,
        'username': username,
        'profile_picture': profilePicture,
        'profile_picture_cdn': profilePictureCdn,
        'designation': designation,
        'is_subscription_active': isSubscriptionActive,
        'is_follow': isFollow,
      };
}

class Category {
  String? title;

  Category({this.title});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        title: json['title'],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
      };
}
