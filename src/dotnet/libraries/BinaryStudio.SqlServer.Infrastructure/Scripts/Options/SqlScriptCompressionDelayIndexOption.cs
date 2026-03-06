using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCompressionDelayIndexOption))]
    internal sealed class SqlScriptCompressionDelayIndexOption : SqlScriptIndexOption<SqlCompressionDelayIndexOption>
        {
        #region ctor{IServiceProvider,SqlCompressionDelayIndexOption}
        public SqlScriptCompressionDelayIndexOption(IServiceProvider context,SqlCompressionDelayIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }