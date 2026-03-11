using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlFragmentSetOnOffStatement<T> : SqlScriptDomObject<T>,ISqlScriptStatement
        where T: SetOnOffStatement
        {
        public String StatementPhrase { get; }
        [UsedImplicitly][Field] public Boolean IsOn { get; }

        #region ctor{IServiceProvider,T}
        protected SqlFragmentSetOnOffStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            StatementPhrase = source.ScriptTokenStream[0].Text.ToUpperInvariant();
            }
        #endregion
        }
    }