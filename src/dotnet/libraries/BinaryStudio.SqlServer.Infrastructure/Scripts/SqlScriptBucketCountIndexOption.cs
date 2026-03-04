using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptBucketCountIndexOption : SqlScriptIndexOption<SqlBucketCountIndexOption>
        {
        #region ctor{IServiceProvider,SqlBucketCountIndexOption}
        public SqlScriptBucketCountIndexOption(IServiceProvider context,SqlBucketCountIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }