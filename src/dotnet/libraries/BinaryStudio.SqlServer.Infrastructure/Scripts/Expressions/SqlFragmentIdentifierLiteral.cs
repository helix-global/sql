using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(IdentifierLiteral))]
    internal sealed class SqlFragmentIdentifierLiteral : SqlFragmentLiteral<IdentifierLiteral>
        {
        #region ctor{IServiceProvider,IdentifierLiteral}
        public SqlFragmentIdentifierLiteral(IServiceProvider context,IdentifierLiteral source)
            : base(context,source)
            {
            }
        #endregion
        }
    }