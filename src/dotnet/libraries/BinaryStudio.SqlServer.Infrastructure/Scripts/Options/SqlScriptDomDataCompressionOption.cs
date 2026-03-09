using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(DataCompressionOption))]
    internal sealed class SqlScriptDomDataCompressionOption : SqlScriptDomIndexOption<DataCompressionOption>
        {
        #region ctor{IServiceProvider,DataCompressionOption}
        public SqlScriptDomDataCompressionOption(IServiceProvider context,DataCompressionOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }