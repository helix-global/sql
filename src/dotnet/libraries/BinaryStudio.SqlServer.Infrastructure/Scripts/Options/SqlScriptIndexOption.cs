using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal class SqlScriptIndexOption<T> : SqlScriptCodeObject<T>,ISqlScriptIndexOption
        where T : SqlIndexOption
        {
        [UsedImplicitly][Field] public String Phrase { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptIndexOption(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        public override String ToString()
            {
            return $"{Phrase.ToLowerInvariant()}";
            }
        #endregion
        }
    }