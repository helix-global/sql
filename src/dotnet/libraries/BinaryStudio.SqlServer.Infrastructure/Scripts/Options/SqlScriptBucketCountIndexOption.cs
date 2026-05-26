using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlBucketCountIndexOption))]
    internal sealed class SqlScriptBucketCountIndexOption : SqlScriptIndexOption<SqlBucketCountIndexOption>
        {
        public override SqlIndexOptionType Type { get { return SqlIndexOptionType.BucketCount; }}

        #region ctor{IServiceProvider,SqlBucketCountIndexOption}
        public SqlScriptBucketCountIndexOption(IServiceProvider context,SqlBucketCountIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }