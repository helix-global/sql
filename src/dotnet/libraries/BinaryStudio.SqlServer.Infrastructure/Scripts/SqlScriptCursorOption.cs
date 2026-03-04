using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCursorOption))]
    internal sealed class SqlScriptCursorOption : SqlScriptCodeObject<SqlCursorOption>
        {
        #region ctor{IServiceProvider,SqlCursorOption}
        public SqlScriptCursorOption(IServiceProvider context,SqlCursorOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }