using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
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