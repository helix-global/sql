using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(DataCompressionOption))]
    internal sealed class SqlFragmentDataCompressionOption : SqlFragmentIndexOption<DataCompressionOption>
        {
        #region ctor{IServiceProvider,DataCompressionOption}
        public SqlFragmentDataCompressionOption(IServiceProvider context,DataCompressionOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }