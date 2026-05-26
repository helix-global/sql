using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(MaxLiteral))]
    internal sealed class SqlFragmentMaxLiteral : SqlFragmentLiteral<MaxLiteral>
        {
        #region ctor{IServiceProvider,MaxLiteral}
        public SqlFragmentMaxLiteral(IServiceProvider context,MaxLiteral source)
            : base(context,source)
            {
            }
        #endregion
        }
    }