using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(OdbcLiteral))]
    internal sealed class SqlFragmentOdbcLiteral : SqlFragmentLiteral<OdbcLiteral>
        {
        #region ctor{IServiceProvider,OdbcLiteral}
        public SqlFragmentOdbcLiteral(IServiceProvider context,OdbcLiteral source)
            : base(context,source)
            {
            }
        #endregion
        }
    }