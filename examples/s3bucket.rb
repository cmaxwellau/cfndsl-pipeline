# frozen_string_literal: true
CloudFormation do
  Description 'S3 Storage integrated with KMS and IAM'
  AWSTemplateFormatVersion '2010-09-09'

  Parameter('ProvisioningRoleID') do
    Description 'IAM RoleID to be allowed to administer KMS Key and access S3'
    Type 'String'
    Default 'AROAABCDEFGHIJKLMNOP'
  end

  Parameter('InstanceRoleID') do
    Description 'IAM RoleID of instance profile using the KMS Key and access S3'
    Type 'String'
    Default 'AROA1234567890123456'
  end

  Parameter('LoggingBucket') do
    Description 'S3 Bucket where access logs from new S3 bucket will be sent'
    Type 'String'
  end

  Parameter('VPCEndpoint') do
    Description 'VPC Endpoint ID'
    Type 'String'
    Default 'vpce-1234abcd5678ef90'
  end

  Parameter('BucketName') do
    Description 'Hexadecimal string for bucket name'
    Type 'String'
    Default 'f4c8e474d09b'
  end
  KMS_Key('KMSKey') do
    Description 'KMS Key for encrypting S3 Bucket'
    Enabled(true)
    EnableKeyRotation(true)
    KeyPolicy({
      'Id' => 'KMS Key Access',
      'Statement' => [
            {
                  'Action' => [
                        'kms:ScheduleKeyDeletion',
                        'kms:Delete*'
                  ],
                  'Effect' => 'Deny',
                  'Principal' => '*',
                  'Resource' => [
                        '*'
                  ],
                  'Sid' => 'DenyDelete'
            },
            {
                  'Action' => [
                        'kms:*'
                  ],
                  'Condition' => {
                        'StringNotLike' => {
                              'aws:userId' => [
                                    FnSub('${ProvisioningRoleID}:*')
                              ]
                        }
                  },
                  'Effect' => 'Deny',
                  'Principal' => '*',
                  'Resource' => [
                        '*'
                  ],
                  'Sid' => 'DenyKeyAccess'
            },
            {
                  'Action' => [
                        'kms:CreateKey',
                        'kms:CreateAlias',
                        'kms:CreateGrant',
                        'kms:Describe*',
                        'kms:Enable*',
                        'kms:List*',
                        'kms:Put*',
                        'kms:Update*',
                        'kms:Revoke*',
                        'kms:Disable*',
                        'kms:Get*',
                        'kms:TagResource',
                        'kms:UntagResource',
                        'kms:CancelKeyDeletion',
                        'kms:GenerateDataKey*'
                  ],
                  'Condition' => {
                        'StringLike' => {
                              'aws:userId' => [
                                    FnSub('${ProvisioningRoleID}:*')
                              ]
                        }
                  },
                  'Effect' => 'Allow',
                  'Principal' => '*',
                  'Resource' => [
                        '*'
                  ],
                  'Sid' => 'AllowAccessForKeyAdministrator'
            },
            {
                  'Action' => [
                        'kms:Encrypt',
                        'kms:Decrypt',
                        'kms:DescribeKey',
                        'kms:GenerateDataKey*'
                  ],
                  'Condition' => {
                        'StringLike' => {
                              'aws:userId' => [
                                    FnSub('${InstanceRoleID}:*')
                              ]
                        }
                  },
                  'Effect' => 'Allow',
                  'Principal' => '*',
                  'Resource' => [
                        '*'
                  ],
                  'Sid' => 'AllowUseOftheKey'
            }
      ],
      'Version' => '2012-10-17'
    })
  end
  S3_BucketPolicy('BucketPolicy') do
    DependsOn('Bucket')
    Bucket(Ref('Bucket'))
    PolicyDocument({
      'Statement' => [
            {
                  'Action' => [
                        's3:*'
                  ],
                  'Condition' => {
                        'Bool' => {
                              'aws:SecureTransport' => [
                                    false
                              ]
                        }
                  },
                  'Effect' => 'Deny',
                  'Principal' => '*',
                  'Resource' => [
                        FnGetAtt('Bucket', 'Arn'),
                        FnSub('${Bucket.Arn}/*')
                  ],
                  'Sid' => 'DenyHTTPAccess'
            },
            {
                  'Action' => [
                        's3:PutObject'
                  ],
                  'Condition' => {
                        'StringNotEquals' => {
                              's3:x-amz-server-side-encryption' => [
                                    'aws:kms'
                              ]
                        }
                  },
                  'Effect' => 'Deny',
                  'Principal' => '*',
                  'Resource' => [
                        FnGetAtt('Bucket', 'Arn'),
                        FnSub('${Bucket.Arn}/*')
                  ],
                  'Sid' => 'DenyIncorrectEncryptionHeader'
            },
            {
                  'Action' => [
                        's3:PutObject'
                  ],
                  'Condition' => {
                        'Null' => {
                              's3:x-amz-server-side-encryption' => [
                                    true
                              ]
                        }
                  },
                  'Effect' => 'Deny',
                  'Principal' => '*',
                  'Resource' => [
                        FnGetAtt('Bucket', 'Arn'),
                        FnSub('${Bucket.Arn}/*')
                  ],
                  'Sid' => 'DenyUnEncryptedObjectUploads'
            },
            {
                  'Action' => [
                        's3:PutObject'
                  ],
                  'Condition' => {
                        'StringNotLikeIfExists' => {
                              's3:x-amz-server-side-encryption-aws-kms-key-id' => [
                                    FnGetAtt('KMSKey', 'Arn')
                              ]
                        }
                  },
                  'Effect' => 'Deny',
                  'Principal' => '*',
                  'Resource' => [
                        FnGetAtt('Bucket', 'Arn'),
                        FnSub('${Bucket.Arn}/*')
                  ],
                  'Sid' => 'DenyAccessIfSpecificKMSKeyIsNotUsed'
            },
            {
                  'Action' => [
                        's3:Delete*'
                  ],
                  'Effect' => 'Deny',
                  'Principal' => '*',
                  'Resource' => [
                        FnGetAtt('Bucket', 'Arn'),
                        FnSub('${Bucket.Arn}/*')
                  ],
                  'Sid' => 'DenyDelete'
            },
            {
                  'Action' => [
                        's3:*'
                  ],
                  'Condition' => {
                        'StringNotEquals' => {
                              'aws:sourceVpce' => FnSub('${VPCEndpoint}')
                        }
                  },
                  'Effect' => 'Deny',
                  'Principal' => '*',
                  'Resource' => [
                        FnGetAtt('Bucket', 'Arn'),
                        FnSub('${Bucket.Arn}/*')
                  ],
                  'Sid' => 'DenyAllExceptConnectAndOthersViaVPCE'
            },
            {
                  'Action' => [
                        's3:PutObject*',
                        's3:Get*',
                        's3:List*'
                  ],
                  'Condition' => {
                        'StringLike' => {
                              'aws:userId' => [
                                    FnSub('${InstanceRoleID}:*')
                              ]
                        }
                  },
                  'Effect' => 'Allow',
                  'Principal' => '*',
                  'Resource' => [
                        FnGetAtt('Bucket', 'Arn'),
                        FnSub('${Bucket.Arn}/*')
                  ],
                  'Sid' => 'AllowObjectReadWrite'
            },
            {
                  'Action' => [
                        's3:*'
                  ],
                  'Condition' => {
                        'StringLike' => {
                              'aws:userId' => [
                                    FnSub('${ProvisioningRoleID}:*')
                              ]
                        }
                  },
                  'Effect' => 'Allow',
                  'Principal' => '*',
                  'Resource' => [
                        FnGetAtt('Bucket', 'Arn'),
                        FnSub('${Bucket.Arn}/*')
                  ],
                  'Sid' => 'AllowBucketConfiguration'
            }
      ],
      'Version' => '2012-10-17'
    })
  end
  S3_Bucket('Bucket') do
    BucketName(FnSub('${BucketName}'))
    Property("BucketEncryption", {
      'ServerSideEncryptionConfiguration' => [
        {
          'ServerSideEncryptionByDefault' => {
            'KMSMasterKeyID' => FnGetAtt('KMSKey', 'Arn'),
            'SSEAlgorithm' => 'aws:kms'
          }
        }
      ]
    })
    Property("PublicAccessBlockConfiguration", {
      'BlockPublicAcls' => true,
      'BlockPublicPolicy' => true,
      'IgnorePublicAcls' => true,
      'RestrictPublicBuckets' => true
    })
    Property("LoggingConfiguration",{
      'DestinationBucketName' => FnSub('${LoggingBucket}'),
      'LogFilePrefix' => FnSub('S3logs/${AWS::AccountId}/${BucketName}/')
    })
    Property("VersioningConfiguration", { 'Status' => 'Enabled' })
  end

  Output('BucketName') do
    Description 'Bucket Arn'
    Value FnGetAtt('Bucket', 'Arn')
  end

  Output('KMSKey') do
    Description 'KMS Key Id'
    Value Ref('KMSKey')
  end
end
