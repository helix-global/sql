using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(CompressionDelayIndexOption))]
    internal sealed class SqlScriptDomCompressionDelayIndexOption : SqlScriptDomIndexOption<CompressionDelayIndexOption>
        {
        #region ctor{IServiceProvider,CompressionDelayIndexOption}
        public SqlScriptDomCompressionDelayIndexOption(IServiceProvider context,CompressionDelayIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }