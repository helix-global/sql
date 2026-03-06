using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlModuleReturnsNullOnNullInputOption))]
    internal sealed class SqlScriptModuleReturnsNullOnNullInputOption : SqlScriptModuleOption<SqlModuleReturnsNullOnNullInputOption>
        {
        #region ctor{IServiceProvider,SqlModuleReturnsNullOnNullInputOption}
        public SqlScriptModuleReturnsNullOnNullInputOption(IServiceProvider context,SqlModuleReturnsNullOnNullInputOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }