using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlComputedColumnDefinition))]
    internal sealed class SqlScriptComputedColumnDefinition : SqlScriptColumnDefinition<SqlComputedColumnDefinition>
        {
        #region ctor{IServiceProvider,SqlComputedColumnDefinition}
        public SqlScriptComputedColumnDefinition(IServiceProvider context,SqlComputedColumnDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }